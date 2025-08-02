FROM python:3.13-slim AS builder

RUN mkdir /app
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN pip install \ 
    --root-user-action=ignore \
    --upgrade pip

COPY requirements.txt /app/
RUN pip install  \
    --root-user-action=ignore \
    --no-cache-dir -r requirements.txt

##
# Stage 2
##

FROM python:3.13-slim
RUN useradd -m -r appuser && \
    mkdir /app && \
    chown -R appuser /app

COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
WORKDIR /app
COPY --chown=appuser:appuser . .

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER appuser
EXPOSE 8000
CMD ["uvicorn", "demo_app.asgi:application", "--host", "0.0.0.0", "--port", "8000"]
