FROM python:3-alpine3.22

RUN mkdir /code

COPY . /code

WORKDIR /code

RUN python3 -m pip install -r requirements.txt

ENTRYPOINT ["python3","wsgi.py"]