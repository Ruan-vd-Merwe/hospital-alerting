    REGION ?= eu-west-1
    STACK  ?= hospitalbedvideo
    BUCKET ?= hospitalbedvideo-ruan-01        # change to a unique name
    ARTIFACTS ?= $(STACK)-artifacts-ruan-01    # change to a unique name
    PHONE  ?= +27746020084
    WARD_PREFIX ?= ward-A3/
    KEY_SUFFIX  ?= .MOV

    ZIP = lambda/function.zip

    PY := python3
    VENV := .venv

    DOCKER := docker compose
    SVC := dev

    .PHONY: all init zip upload deploy outputs test sms-attrs setup venv deps docker-shell docker-deploy docker-test

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

    # Test upload (.MOV to match suffix)
    test:
    	aws s3 cp sample.MOV s3://$(BUCKET)/$(WARD_PREFIX)bed-4/videos/test.MOV --region $(REGION)

    # Local Python helpers
    setup: venv deps

    venv:
    	@[ -d $(VENV) ] || $(PY) -m venv $(VENV)

    deps:
    	. $(VENV)/bin/activate && pip install --upgrade pip && \
	pip install -r requirements.txt

    # --- Docker helpers ---
    docker-shell:
    	$(DOCKER) run --rm $(SVC)

    docker-deploy:
    	$(DOCKER) run --rm $(SVC) make deploy

    docker-test:
    	$(DOCKER) run --rm $(SVC) bash -lc "touch sample.MOV && make test"
