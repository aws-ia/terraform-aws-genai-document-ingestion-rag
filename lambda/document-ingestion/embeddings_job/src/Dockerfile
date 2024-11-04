FROM public.ecr.aws/lambda/python:3.12

COPY requirements.txt ./

RUN python -m pip install --upgrade pip

RUN pip install -r requirements.txt

COPY . .

CMD ["lambda.handler"]
