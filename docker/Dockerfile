FROM python:3.9-slim-buster

RUN pip install --no-cache-dir flask

WORKDIR /app

COPY app.py .

EXPOSE 8080

CMD [ "python", "./app.py" ]

