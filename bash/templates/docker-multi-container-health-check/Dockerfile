# last_verified: 2026-08-15 · bash
# Web-app image: Python 3.12 + Flask, non-root runtime user.
FROM python:3.12-slim

RUN pip install --no-cache-dir flask redis

COPY app.py /app/app.py
WORKDIR /app
EXPOSE 5000
USER 1000
CMD ["python", "app.py"]
