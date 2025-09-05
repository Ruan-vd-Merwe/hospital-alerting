# Ward-Alert MVP (S3 -> Lambda -> SNS SMS)

Uploads to S3 under a ward prefix trigger a Lambda that sends an SMS `ALERT: Bed X` to a shared ward phone.

## Quickstart
1. Configure your AWS CLI. Set region (e.g., af-south-1) and phone number in `Makefile`.
2. Put the Lambda code in `lambda/lambda_handler.py`.
3. Run:
   ```bash
   make deploy
   ```
4. Test:
   ```bash
   touch sample.mp4 && make test
   # Phone should receive: "ALERT: Bed 4"
   ```

## Key rules
- Keys should include a bed token like `bed-4`, `bed_4`, or `bed 4` (case-insensitive).
- Only objects under `WardPrefix` (default `ward-A3/`) and matching `KeySuffix` (default `.mp4`) trigger alerts.

## Change ward or bed
- Change `WARD_PREFIX` in `Makefile` or pass at runtime: `make deploy WARD_PREFIX=ward-B2/`.
- Bed number is parsed from the object key — upload to `.../bed-7/...` to alert Bed 7.

## Notes
- SMS costs apply; we set SMS to Transactional and a small monthly spend by default.
- To use email instead of SMS, add an email subscription to the SNS topic.
- For a custom ringtone and ACK button, replace SMS with a lightweight Android app + push notifications.
