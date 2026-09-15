# MoneyPrinterTurbo para Hugging Face Spaces (Docker).
#
# Usa a imagem de release oficial publicada pelo projeto (a mesma do
# docker-compose.release.yml). Isso evita reconstruir do zero no HF:
# o build deste Dockerfile leva poucos segundos.
FROM ghcr.io/harry0703/moneyprinterturbo:latest

# Alternativa (se a imagem do GHCR não estiver acessível): construir a partir
# do Dockerfile do próprio repositório, copiando-o para a raiz deste Space
# junto com requirements.txt e o código. O build passa de ~1 min para ~10 min.
#
# FROM python:3.11-slim-bullseye
# ... (copie o conteúdo do Dockerfile do repositório,
#      mudando ARG PIP_USE_OFFICIAL=1 e ARG DOCKER_BUILD_MIRROR=default)

COPY entrypoint.sh /usr/local/bin/mpt-entrypoint.sh
RUN chmod +x /usr/local/bin/mpt-entrypoint.sh

# O HF Spaces roteia o tráfego para a porta declarada no README.md
# (front-matter "app_port: 8501").
EXPOSE 8501

ENTRYPOINT ["/usr/local/bin/mpt-entrypoint.sh"]
