FROM python:3.8

# Allow statements and log messages to immediately appear in the Cloud Run logs
ENV PYTHONUNBUFFERED True

COPY requirements.txt .
RUN pip install -r requirements.txt

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY model.py main.py ./

CMD exec gunicorn --bind :$PORT --workers 1 --threads 1 --timeout 0 main:app
