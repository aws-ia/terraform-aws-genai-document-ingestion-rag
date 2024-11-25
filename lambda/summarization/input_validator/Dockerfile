FROM public.ecr.aws/lambda/python:3.12

RUN dnf update -y && \
    dnf install -y python3-devel gcc git && \
    dnf clean all

COPY requirements.txt ./

RUN pip install -r requirements.txt --verbose

COPY . .

CMD ["lambda.handler"]
