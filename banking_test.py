import dspy
import random
from dspy.datasets import DataLoader
from datasets import load_dataset

CLASSES = load_dataset("PolyAI/banking77", split="train", trust_remote_code=True).features['label'].names
kwargs = dict(fields=("text", "label"), input_keys=("text",), split="train", trust_remote_code=True)

TOP_CLASSES = CLASSES[:]

raw_data = [
    dspy.Example(x, label=CLASSES[x.label]).with_input("text")
    for x in DataLoader().from_huggingface("PolyAI/banking77", **kwargs)
    if CLASSES[x.label] in TOP_CLASSES
][:2000]

random.Random(42).shuffle(raw_data)
print(len(TOP_CLASSES))
trainset = raw_data[:400]
valset = raw_data[400:450]
assert len(valset) > 30

#print(trainset[0])

classify = dspy.ChainOfThought(f"text -> label: Literal{TOP_CLASSES}")

from dspy.clients.lm_local_arbor import ArborProvider
port = 7453
arbor_api_base = f"http://localhost:{port}/v1/"
api_key = "arbor"
provider = ArborProvider()

student_lm_name = "Qwen/Qwen2.5-1.5B-Instruct"
#student_lm_name = "Qwen/Qwen2.5-7B-Instruct"
#student_lm_name = "Qwen/Qwen2.5-14B-Instruct"
#student_lm_name = "Qwen/Qwen2.5-32B-Instruct"
student_lm = dspy.lm(model=f"openai/arbor:{student_lm_name}", provider=provider, temperature=0.7, api_base=arbor_api_base, api_key=api_key)

student_classify = classify.deepcopy()
student_classify.set_lm(student_lm)

metric = (lambda x, y, trace=None: x.label == y.label)

from dspy.teleprompt.grpo import GRPO
train_kwargs = {
    'per_device_train_batch_size': 4,
    'temperature': 0.7,
    'beta': 0.02,
    'learning_rate': 1e-5,
    'gradient_checkpointing': False,
    'bf16': True,
    'lr_scheduler_type': 'constant_with_warmup',
    'max_prompt_length': None,
    'max_completion_length': None,
    'lora': False,
    'report_to': 'none', # 'wandb'
    'log_completions': False,
}

compiler = GRPO(
    metric=metric,
    multitask=True,
    num_dspy_examples_per_grpo_step=4,
    num_rollouts_per_dspy_example=4,
    exclude_demos=True,
    num_train_steps=50,
    num_threads=8,
    use_train_as_val=False,
    num_steps_for_val=10,
    train_kwargs=train_kwargs,
)

classify_ft = compiler.compile(
    student=student_classify,
    trainset=trainset,
    valset=valset,
)

evaluate = dspy.Evaluate(
    devset=valset,
    metric=metric,
    display_progress=True,
    display_table=5,
    num_threads=16,
)