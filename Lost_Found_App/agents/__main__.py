from classifier_agent import ClassifierAgent
from extractor_agent import ExtractorAgent
from matcher_agent import MatcherAgent

if __name__ == "__main__":
    message = "I have lost my mobile phone at the faculty canteen yesterday."
    
    # classify
    classifier = ClassifierAgent()
    classification = classifier.classify(message)

    print(f"Message: {message}")
    print(f"Classification: {classification}")

    if classification in ["LOST", "FOUND"]:
        # extractor
        extracted = ExtractorAgent.extract_details(message, classification)
        print(f"Extracted Details: {extracted}")
 
        extracted['status'] = classification

        # matcher
        matcher = MatcherAgent()
        match_result = matcher.match(extracted)
        print(f"Match Result: {match_result}")

    else:
        print("No details to extract.")
