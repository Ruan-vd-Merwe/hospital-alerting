import os, re, boto3

sns = boto3.client("sns")
TOPIC_ARN = os.environ["TOPIC_ARN"]

# Matches 'bed-4', 'bed_4', 'bed 4' (case-insensitive)
BED_RE = re.compile(r"bed[-_/ ]?(\d+)", re.IGNORECASE)

def handler(event, context):
    for rec in event.get("Records", []):
        s3 = rec.get("s3", {})
        key = s3.get("object", {}).get("key", "")
        bed = "?"
        m = BED_RE.search(key)
        if m:
            bed = m.group(1)
        msg = f"ALERT: Bed {bed}"
        sns.publish(TopicArn=TOPIC_ARN, Message=msg)
    return {"ok": True}
