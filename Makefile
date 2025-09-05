    REGION ?= af-south-1
    STACK  ?= ward-alert-a3
    BUCKET ?= ruan-ward-a3-uploads     # must be globally unique
    ARTIFACTS ?= $(STACK)-artifacts
    PHONE  ?= +27XXXXXXXXX
    WARD_PREFIX ?= ward-A3/
    KEY_SUFFIX  ?= .mp4

    ZIP= lambda/function.zip

    .PHONY: all init zip upload deploy outputs test sms-attrs

    all: deploy outputs

    init:
	aws s3 mb s3://$(ARTIFACTS) --region $(REGION) || true

    zip:
	mkdir -p lambda
	cd lambda && zip -r ../function.zip .

    upload: zip init
	aws s3 cp $(ZIP) s3://$(ARTIFACTS)/lambda/function.zip --region $(REGION)

    sms-attrs:
	aws sns set-sms-attributes \
	  --attributes DefaultSMSType=Transactional,MonthlySpendLimit=10,DefaultSenderID=WARD \
	  --region $(REGION) || true

    deploy: sms-attrs upload
	aws cloudformation deploy \
	  --stack-name $(STACK) \
	  --template-file infra/template.yml \
	  --capabilities CAPABILITY_NAMED_IAM \
	  --region $(REGION) \
	  --parameter-overrides \
	    Region=$(REGION) \
	    BucketName=$(BUCKET) \
	    PhoneNumber=$(PHONE) \
	    CodeS3Bucket=$(ARTIFACTS) \
	    CodeS3Key=lambda/function.zip \
	    WardPrefix=$(WARD_PREFIX) \
	    KeySuffix=$(KEY_SUFFIX)

    outputs:
	aws cloudformation describe-stacks --stack-name $(STACK) --region $(REGION) \
	  --query 'Stacks[0].Outputs' --output table

    # Test upload (expects sample.mp4 present)
    test:
	aws s3 cp sample.mp4 s3://$(BUCKET)/$(WARD_PREFIX)bed-4/videos/test.mp4 --region $(REGION)
