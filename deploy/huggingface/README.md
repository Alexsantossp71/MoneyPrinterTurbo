---
title: MoneyPrinterTurbo
emoji: 🎬
colorFrom: blue
colorTo: purple
sdk: docker
app_port: 8501
pinned: false
---

# MoneyPrinterTurbo 🎬

Geração de vídeos curtos por IA: informe um tema e o app gera o roteiro,
busca os materiais, narra com voz sintética, cria legendas e renderiza o
vídeo final (9:16, 16:9 ou 1:1).

## Como usar

1. Abra a aba **App** deste Space (aguarde o build na primeira vez).
2. No menu lateral, em **Configurações básicas**, informe as chaves de API
   desejadas (LLM, Pexels/Pixabay etc.) — ou use o modo sem chave:
   roteiro manual + Edge TTS (grátis) + materiais próprios.
3. Escreva o tema do vídeo e clique em **Gerar Vídeo**.

## Configuração persistente

O armazenamento do Space é temporário. Para manter suas chaves de API entre
reinicializações, defina um **Secret** chamado `MPT_CONFIG_TOML` nas
*Settings* do Space, contendo o conteúdo completo do seu `config.toml`.

Projeto original: [harry0703/MoneyPrinterTurbo](https://github.com/harry0703/MoneyPrinterTurbo) (MIT)
