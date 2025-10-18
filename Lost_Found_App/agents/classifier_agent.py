import sys
import os
from typing import Literal

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from core.llm_client import generate_content


class ClassifierAgent:
    """
    LLM-powered classifier agent to classify a message as LOST / FOUND / UNKNOWN
    """

    def __init__(self):
        pass

    def _build_prompt(self, text: str) -> str:
        return (
            "You are a strict classification assistant.\n"
            "Read the following user report and respond with ONE WORD ONLY — "
            "either LOST, FOUND, or UNKNOWN.\n\n"
            "Definitions:\n"
            "- LOST: The person no longer has an item (lost, misplaced, dropped, left behind).\n"
            "- FOUND: The person discovered or picked up an item (found, recovered, came across).\n"
            "- UNKNOWN: The report is unrelated to lost or found items.\n\n"
            f"User report: {text}\n\n"
            "Answer strictly with only one of these words:\n"
            "LOST\nFOUND\nUNKNOWN"
        )

    def classify(self, text: str) -> Literal["LOST", "FOUND", "UNKNOWN"]:
        prompt = self._build_prompt(text)
        try:
            raw_label = generate_content(prompt)
            print(f"[DEBUG] Raw LLM response: {raw_label}")

            label = raw_label.strip().split()[0].upper() if raw_label else "UNKNOWN"
            if label not in ["LOST", "FOUND", "UNKNOWN"]:
                print(f"[DEBUG] Invalid label '{label}', defaulting to UNKNOWN")
                label = "UNKNOWN"

            print(f"[DEBUG] Final classification: {label}")
            return label

        except Exception as e:
            print("Error during classification:", e)
            return "UNKNOWN"
