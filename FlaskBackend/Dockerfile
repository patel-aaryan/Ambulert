FROM python:3.7-alpine

WORKDIR /app

RUN pip install flask && pip install vincenty && pip install flask-cors

COPY ./Ambulert.py /app

CMD ["python", "Ambulert.py"]