FROM python:3.13-slim

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

EXPOSE 5000

ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=5000

CMD ["python", "app/app.py"]