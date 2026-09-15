# Guia: publicar o MoneyPrinterTurbo na web (grátis)

> **Resposta direta:** o GitHub Pages **não roda** este app. A alternativa
> gratuita com o fluxo mais parecido ("push no repositório → site no ar")
> é o **Hugging Face Spaces**, que este guia configura em ~10 minutos.

---

## 1. Por que o GitHub Pages não funciona

O GitHub Pages serve **apenas arquivos estáticos** (HTML, CSS, JS). Ele não
executa nenhum código no servidor. O MoneyPrinterTurbo precisa de:

| Necessidade | Por quê |
|---|---|
| **Python 3.11 + FFmpeg** rodando no servidor | Geração de roteiro, narração, legendas e renderização de vídeo |
| **Processos de longa duração** | Renderizar um vídeo leva minutos de CPU |
| **Chaves de API guardadas no servidor** | LLM, bancos de imagens etc. (nunca seguras num site estático) |
| **Sistema de arquivos** | Salvar vídeos, áudios e histórico de tarefas |

Ou seja: precisa de um **servidor**, não de hospedagem estática. Nenhum
serviço do tipo "GitHub Pages" (Netlify static, Cloudflare Pages etc.)
serve. O que existe de mais parecido em filosofia é o **Hugging Face Spaces**:
você cria um repositório, sobe os arquivos e o serviço constrói e roda o
contêiner Docker para você, com URL pública.

## 2. O que você vai criar

```
GitHub Pages                       Hugging Face Spaces
─────────────                      ───────────────────
push de HTML → site estático       push de Dockerfile → app rodando
❌ não executa Python              ✅ Python + FFmpeg + URL pública
grátis, ilimitado                  grátis (2 vCPU, 16 GB RAM, "dorme" sem uso)
```

Este diretório (`deploy/huggingface/`) contém os 3 arquivos que vão para a
**raiz** do seu Space:

| Arquivo | Função |
|---|---|
| `README.md` | Metadados do Space (SDK Docker, porta 8501) + instruções |
| `Dockerfile` | Baseia-se na imagem oficial `ghcr.io/harry0703/moneyprinterturbo` (build em segundos) |
| `entrypoint.sh` | Restaura suas chaves de API do Secret `MPT_CONFIG_TOML` a cada reinício e sobe a WebUI |

## 3. Passo a passo

### Passo 1 — Criar a conta e o Space

1. Crie uma conta gratuita em **huggingface.co** (pode entrar com o GitHub).
2. Clique no seu avatar → **New Space**.
3. Configure:
   - **Space name:** `moneyprinterturbo` (a URL final será
     `https://SEU-USUÁRIO-moneyprinterturbo.hf.space`)
   - **SDK:** `Docker` → *Blank*
   - **Visibility:** ⚠️ **Private** (veja o aviso de segurança na seção 5)
4. Clique em **Create Space**.

### Passo 2 — Subir os 3 arquivos

Na página do Space (aba **Files**):

1. **Add file → Upload files**.
2. Envie `README.md`, `Dockerfile` e `entrypoint.sh` (deste diretório).
3. **Commit changes to main**.

O build começa na hora (aba **Logs**). Como a imagem já vem pronta do GHCR,
leva pouco tempo. Quando terminar, a aba **App** mostra a WebUI em português
(basta o navegador estar em pt-BR).

> Também funciona por linha de comando, como num repositório git normal:
> ```bash
> git clone https://huggingface.co/spaces/SEU-USUARIO/moneyprinterturbo
> cd moneyprinterturbo
> cp /caminho/do/repo/deploy/huggingface/{README.md,Dockerfile,entrypoint.sh} .
> git add . && git commit -m "deploy" && git push
> ```

### Passo 3 — Salvar suas chaves de API (Secret)

O armazenamento do Space é **temporário**: quando o contêiner reinicia, o
`config.toml` onde a WebUI guarda suas chaves é apagado. A solução incluída
no `entrypoint.sh`:

1. Copie o `config.example.toml` do repositório e preencha **apenas** as
   chaves que você usa (ex.: `pexels_api_keys`, sua LLM, `api_key` da API...).
   **Dica:** não precisa do arquivo inteiro — uma config mínima também
   funciona, pois o app trata chaves ausentes como "não configuradas":

   ```toml
   [app]
   llm_provider = "gemini"
   gemini_api_key = "SUA_CHAVE_DO_GEMINI"       # grátis: aistudio.google.com/app/apikey
   pexels_api_keys = ["SUA_CHAVE_DO_PEXELS"]    # grátis: pexels.com/api
   ```

   **Alternativa grátis ao Gemini — OpenRouter:** conta em
   [openrouter.ai](https://openrouter.ai) (Google/GitHub, sem cartão), chave em
   [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys). Use
   `llm_provider = "openrouter"` + `openrouter_api_key` — o modelo padrão do
   projeto é gratuito (`google/gemma-4-31b-it:free`); outros em
   [openrouter.ai/models?variant=free](https://openrouter.ai/models?variant=free)
   (via `openrouter_model_name`).

   > ⚠️ **Importante ao usar o OpenRouter neste Space:** a imagem Docker
   > oficial usada pelo kit ainda tem como padrão o modelo
   > `minimax/minimax-m3:free`, que foi descontinuado do catálogo grátis
   > (erro 404). **Defina o modelo explicitamente** no Secret, assim:
   >
   > ```toml
   > [app]
   > llm_provider = "openrouter"
   > openrouter_api_key = "sk-or-v1-SUA_CHAVE"
   > openrouter_model_name = "google/gemma-4-31b-it:free"
   > pexels_api_keys = ["SUA_CHAVE_PEXELS"]
   > ```

   (Narração: Edge TTS, padrão e grátis, não precisa de chave. Lista completa
   de provedores e nomes de chaves: seção `[app]` do `config.example.toml`.)
2. No Space: **Settings → Variables and secrets → New secret**:
   - **Name:** `MPT_CONFIG_TOML`
   - **Value:** todo o conteúdo do seu `config.toml` (cole o arquivo inteiro)
3. Reinicie o Space (**Settings → Factory reboot** ou pause/resume).

Pronto: a cada reinício, suas chaves são restauradas automaticamente. Sem
nenhuma chave, o app ainda funciona no modo manual (roteiro próprio + Edge
TTS grátis + materiais enviados do seu computador).

### Passo 4 (opcional) — Deploy automático a partir do GitHub

O arquivo `deploy/huggingface/github-action-deploy-huggingface.yml` é um
workflow do GitHub Actions que envia os arquivos de `deploy/huggingface/`
para o Space sempre que mudarem no branch `main`. Como ele precisa viver em
`.github/workflows/` para funcionar, ative-o manualmente (uma vez só):

1. No GitHub, abra o arquivo
   `deploy/huggingface/github-action-deploy-huggingface.yml` no seu fork e
   copie o conteúdo.
2. Vá em **Add file → Create new file**, nomeie-o
   `.github/workflows/deploy-huggingface.yml`, cole o conteúdo e commite.
3. No Hugging Face: **Settings → Access Tokens → New token**, permissão
   **Write**. Copie o token.
4. No seu fork no GitHub: **Settings → Secrets and variables → Actions →
   New repository secret**:
   - `HF_TOKEN` = o token criado acima
   - `HF_SPACE` = `seu-usuario/moneyprinterturbo`
5. Pronto — todo push que altere `deploy/huggingface/**` rePublica o Space
   (ou rode manualmente na aba **Actions → Deploy to Hugging Face Space**).

## 4. Limitações do plano grátis do HF Spaces

- **2 vCPU e 16 GB RAM:** a renderização é mais lenta que num PC bom —
  um vídeo de 1 minuto pode levar vários minutos para ser gerado.
- **"Dorme" após 48 h sem acesso:** basta abrir a URL para acordar
  (a primeira carga demora um pouco mais).
- **Armazenamento efêmero:** histórico de tarefas e vídeos gerados somem
  quando o Space reinicia — **baixe seus vídeos** ao terminar cada geração.
- Uso intensivo e contínuo pode esbarrar nos limites de uso justo do plano
  gratuito.

## 5. ⚠️ Segurança — leia antes de tornar o Space público

A WebUI (Streamlit) **não tem tela de login**. Se o Space estiver **público**,
qualquer pessoa que encontrar a URL pode usar a interface — e **gastar as
suas chaves de API** (LLM, geração de vídeo paga etc.). Por isso:

1. Mantenha o Space **Private**. Só você (logado no Hugging Face) consegue
   abrir o app.
2. Se precisar compartilhar, prefira adicionar pessoas específicas em
   *Settings → Access*.
3. Se mesmo assim quiser público: use apenas chaves gratuitas (Edge TTS,
   Pexels) e monitore o consumo das pagas.

## 6. Alternativas (se o HF Spaces não atender)

| Serviço | Custo | Prós | Contras |
|---|---|---|---|
| **Google Colab** (notebook oficial no README do projeto) | Grátis | Zero configuração | Sessão morre; uso pessoal |
| **Oracle Cloud Always Free** | Grátis (VPS ARM 4 núcleos/24 GB) | Sempre ligado, potente | Pedido de conta exige cartão; setup técnico |
| **Seu próprio PC + Cloudflare Tunnel ou Tailscale** | Grátis | Sua máquina, sem limite | PC precisa ficar ligado |
| **VPS (Hetzner, Contabo, etc.)** | ~R$ 25–50/mês | Estável, rápido, storage persistente | Pago |

Em qualquer VPS, o comando oficial é:
```bash
docker compose -f docker-compose.release.yml up -d
```

---

*Arquivos deste kit: `README.md`, `Dockerfile`, `entrypoint.sh` + workflow opcional
`deploy/huggingface/github-action-deploy-huggingface.yml` (ative-o em
`.github/workflows/` seguindo o Passo 4).*
