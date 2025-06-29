FROM python:3-alpine3.22

WORKDIR /code
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000          # ou 5000 si ton app écoute dessus
ENTRYPOINT ["python3", "wsgi.py"]