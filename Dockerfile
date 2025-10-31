FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["pytest", "--maxfail=1", "--disable-warnings", "-q"]
