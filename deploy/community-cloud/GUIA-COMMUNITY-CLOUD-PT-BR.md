# Guia: rodar o MoneyPrinterTurbo no Streamlit Community Cloud (grátis)

> **Resumo:** o [Streamlit Community Cloud](https://streamlit.io/cloud) hospeda
> apps Streamlit de graça, direto do seu repositório GitHub — é a opção mais
> próxima de "GitHub Pages" que realmente executa Python. Este guia publica a
> WebUI do MoneyPrinterTurbo lá em ~5 minutos.
>
> **Plano principal continua sendo o Hugging Face Spaces** (16 GB de RAM vs
> ~1 GB; veja `deploy/huggingface/GUIA-DEPLOY-PT-BR.md`). Use o Community
> Cloud para testes e vídeos curtos.

---

## 1. O que já foi preparado neste repositório

| Arquivo | Por quê |
|---|---|
| `webui/requirements.txt` | O Community Cloud procura o arquivo de dependências **primeiro no diretório do entrypoint** e depois na raiz; na raiz o `uv.lock` teria precedência. Este arquivo força a instalação via `pip` com as versões pinadas |
| `packages.txt` (raiz) | Instala o `ffmpeg` do sistema (apt) — a plataforma é Debian |
| Patch em `webui/Main.py` | Restaura o `config.toml` (chaves de API) a partir do Secret `MPT_CONFIG_TOML` a cada reinício do contêiner, já que o armazenamento é efêmero |

O FFmpeg também funcionaria sem o `packages.txt` (o projeto usa o binário do
pacote pip `imageio-ffmpeg` como fallback), mas o ffmpeg do sistema é mais
completo e é a primeira opção do app.

## 2. Pré-requisitos

- Conta no [streamlit.io](https://streamlit.io) — entre com o GitHub
- O deploy lê **direto do seu fork** (`Alexsantossp71/MoneyPrinterTurbo`),
  que é público — confirme que as alterações deste kit estão no branch
  que você vai usar no deploy

## 3. Passo a passo

### Passo 1 — Criar o app

1. Acesse [share.streamlit.io](https://share.streamlit.io) (ou
   *streamlit.io → Deploy*).
2. **New app** → selecione o repositório do fork e o branch.
3. Preencha:
   - **Main file path:** `webui/Main.py`
   - **Advanced settings → Python version:** `3.11`
4. Clique em **Deploy**.

O primeiro boot demora alguns minutos (instalação das dependências). Quando
terminar, a WebUI abre em `https://SEU-USUARIO-moneyprinterturbo.streamlit.app`
— em português, se seu navegador estiver em pt-BR.

### Passo 2 — Salvar suas chaves de API (Secret)

O armazenamento é efêmero: quando o contêiner reinicia, o `config.toml` onde
a WebUI guarda suas chaves é apagado. A solução já embutida no `Main.py`:

1. Copie o `config.example.toml` e preencha **apenas** o que você usa
   (`pexels_api_keys`, sua LLM, `api_key` da API...).
2. No painel do app (canto inferior direito → **⋮ → Settings**, ou
   *share.streamlit.io → seu app → Settings*) abra **Secrets** e cole:

   ```toml
   MPT_CONFIG_TOML = """
   [app]
   llm_provider = "gemini"
   gemini_api_key = "SUA_CHAVE_DO_GEMINI"
   pexels_api_keys = ["SUA_CHAVE_DO_PEXELS"]
   """
   ```

   > Atenção: as triplas aspas (`"""`) são obrigatórias — o valor é uma
   > **string** com o arquivo inteiro, não TOML estruturado.

   **Você não precisa do config.toml completo.** O app trata chaves ausentes
   como "não configuradas" e só reclama quando um recurso é usado sem a
   chave correspondente — uma config mínima com apenas as linhas acima já
   resolve. Exemplos:

   - **Combo 100% grátis (recomendado):** `gemini` (LLM com nível grátis —
     chave em [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey))
     + `pexels` (banco de imagens grátis — chave em
     [pexels.com/api](https://www.pexels.com/api/)). Narração: Edge TTS
     (padrão, grátis, sem chave).
   - **Gemini deu problema? OpenRouter também é grátis:** crie a conta em
     [openrouter.ai](https://openrouter.ai) (Google/GitHub, sem cartão) e a
     chave em [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys).
     Use `llm_provider = "openrouter"` + `openrouter_api_key` — o modelo
     padrão do projeto é um modelo gratuito (`google/gemma-4-31b-it:free`). Outros
     modelos grátis: [openrouter.ai/models?variant=free](https://openrouter.ai/models?variant=free)
     (defina via `openrouter_model_name`). Os modelos `:free` entram e saem
     do catálogo — se aparecer erro **404 "model is unavailable for free"**,
     escolha outro da lista e atualize o `openrouter_model_name`. Sujeito a
     limites diários do plano grátis.
   - **Sem nenhuma chave:** não configure o Secret — use o modo manual
     (roteiro próprio + materiais enviados do seu computador).
   - **Outro LLM:** troque `llm_provider` e a chave correspondente —
     `openai` + `openai_api_key`, `deepseek` + `deepseek_api_key`,
     `moonshot` + `moonshot_api_key` etc. (todos os nomes estão no
     `config.example.toml`, seção `[app]`).
   - **Imagens:** `pexels_api_keys` e `pixabay_api_keys` são **listas** —
     repare nos colchetes `[...]`.

3. **Save** e reinicie o app (*⋮ → Reboot app*, ou pause/reboot em
   *Manage app*). A cada reinício as chaves são restauradas sozinhas.

Sem nenhuma chave, o app funciona no modo manual: roteiro próprio + Edge TTS
(grátis) + materiais enviados do seu computador.

## 4. Limitações importantes do plano grátis

- **Memória:** ~1 GB garantido por app, teto de ~2,7 GB no pool compartilhido.
  A renderização de vídeo com MoviePy é o gargalo — **use vídeos curtos**
  (na casa de 30–60 s). Apps que estouram o limite são derrubados.
- **Legendas:** mantenha o modo `edge` (padrão). **Não** ative o modo
  `whisper` no Community Cloud — o modelo `large-v3` (~3 GB) não cabe na RAM.
- **Dormência:** apps sem tráfego dormem depois de horas; abrir a URL desperta
  (a primeira carga demora mais).
- **Armazenamento efêmero:** histórico e vídeos gerados somem ao reiniciar —
  **baixe cada vídeo** ao terminar a geração.
- **Privacidade:** apps públicos são ilimitados, mas **qualquer pessoa com a
  URL pode usar a interface (e as suas chaves)**. A conta permite apenas
  **um app privado** — se o app for público, use só chaves gratuitas
  (Edge TTS, Pexels) e monitore as pagas.
- As alterações de código precisam estar no GitHub: todo push no branch do
  app reconstrói automaticamente.

## 5. Problemas comuns

| Sintoma | Causa provável | Solução |
|---|---|---|
| App reinicia sozinho / "Your app has died" | Estouro de memória na renderização | Reduza a duração do vídeo / número de clipes; gere 1 vídeo por vez |
| Primeiro acesso muito lento | App acordando + cold start | Aguarde 1–2 min e recarregue |
| Chaves sumiram | Contêiner reiniciou sem Secret | Configure `MPT_CONFIG_TOML` (Passo 2) e reinicie |
| Erro de codec no FFmpeg | — | O `packages.txt` já instala o ffmpeg completo; confirme que ele está no branch do deploy |

## 6. Community Cloud × Hugging Face Spaces

| | Community Cloud | HF Spaces (kit deste repo) |
|---|---|---|
| RAM | ~1 GB (teto 2,7 GB) | 16 GB |
| Deploy | 1 clique a partir do GitHub | Upload de 3 arquivos (ou Action) |
| Docker/apt | ❌ (só `packages.txt`) | ✅ completo |
| Privacidade | 1 app privado por conta | Spaces privados ilimitados |
| Indicado para | Testes, vídeos curtos | Uso principal |
