FROM python:3.7.1-alpine
MAINTAINER Alec Rubin "alecjakerubin@gmail.com"

RUN apk add --update --no-cache python python-dev py-pip build-base

COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT ["gunicorn"]
CMD ["-w", "4", "--bind", "0.0.0.0:5000", "app:app"]