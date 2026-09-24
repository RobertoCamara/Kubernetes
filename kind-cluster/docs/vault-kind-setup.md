# Vault no kind - instalação inicial

Este documento registra o passo a passo para instalar, inicializar e acessar o Vault em um cluster `kind`, usando armazenamento persistente no host e acesso via `NodePort`, sem `port-forward`.

## Objetivo

Garantir que o Vault:

- permaneça persistente no host WSL/Ubuntu
- não perca estado ao reiniciar o pod ou recriar o cluster
- fique acessível via `http://localhost:8200`
- seja inicializado corretamente na primeira execução

---

## 1) Persistência do Vault no ambiente local

O projeto usa um `hostPath` persistente em:

```bash
/var/lib/kind-data/vault
```

Esse diretório é montado dentro do pod em:

```bash
/vault/data
```

A configuração do Helm usa `storage "file"` com esse caminho. Isso garante que o estado do Vault não seja perdido em reinicializações do pod ou do cluster, em vez de usar o modo `dev`, que é efêmero.

No WSL/Ubuntu, esse diretório foi mantido em um local do host acessível pelo `kind`, e a permissão foi ajustada para o usuário do container do Vault, para evitar erros como:

```text
failed to persist keyring: mkdir /vault/data/core: permission denied
```

Para criar o diretório persistente no host, use:

```bash
sudo mkdir -p /var/lib/kind-data/vault
sudo chown -R 100:1000 /var/lib/kind-data/vault
sudo chmod -R 0770 /var/lib/kind-data/vault
```

> O ponto importante é que o diretório de dados precisa ter permissão de escrita para o processo do container do Vault. Nesse projeto, isso foi resolvido com o diretório em `/var/lib/kind-data/vault` e a configuração correta de ownership/permissões.

As credenciais geradas durante a inicialização são armazenadas separadamente no host em:

```bash
/var/lib/kind-data/vault-bootstrap.json
```

Esse arquivo contém a chave de unseal e o token raiz. Ele é criado com permissão restrita (`600`) e deve ser preservado em local seguro. O script usa esse arquivo para destravar automaticamente o Vault quando o cluster `kind` é recriado.

---

## 2) Instalar o Vault com o script principal

Sempre use o script principal do projeto:

```bash
cd /home/roberto/projects/Kubernetes/kind-cluster
./vault/install-vault.sh
```

Esse script já aplica a configuração de instalação correta do Vault no namespace `vault`, com a persistência e os `NodePort` esperados para o ambiente local do `kind`.

---

## 3) Verificar se o Vault está pronto

Essa verificação é opcional. Durante a instalação, o próprio script aguarda o pod iniciar, inicializa e destrava o Vault automaticamente.

```bash
kubectl get pods -n vault
kubectl get svc -n vault
curl -sS http://localhost:8200/v1/sys/health
```

O retorno esperado deve indicar algo como:

```json
{
  "initialized": false,
  "sealed": true,
  "standby": false
}
```

Esse estado é normal antes da primeira inicialização.

---

## 4) Bootstrap inicial automático

Não é necessário executar manualmente os comandos de inicialização. O script principal do projeto executa todo o bootstrap automaticamente quando o Vault ainda está no estado inicial.

Quando o Vault ainda não foi inicializado, o fluxo realizado pelo script é:

1. aguarda o pod ficar pronto
2. executa `vault operator init`
3. extrai a chave de unseal e o token raiz
4. grava o resultado completo em `/var/lib/kind-data/vault-bootstrap.json`
5. executa `vault operator unseal`
6. imprime os valores e o local das credenciais para uso local

Como referência, este é o comando executado internamente pelo script:

```bash
kubectl exec -n vault pod/vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json
```

Exemplo de saída:

```json
{
  "unseal_keys_b64": ["..."],
  "root_token": "..."
}
```

### Para que serve o init?

O comando `vault operator init`:

- cria o estado de inicialização do Vault
- gera as chaves de destravar (unseal)
- gera o token raiz para administração inicial
- marca o Vault como inicializado e pronto para o primeiro unseal

Sem esse passo, o Vault continua em estado `sealed` e não pode operar normalmente.

> Não execute esse comando novamente em um Vault já inicializado. O script já salva esse resultado em `/var/lib/kind-data/vault-bootstrap.json`. Preserve esse arquivo em local seguro, pois ele é essencial para acessar e administrar o Vault posteriormente.

### Resultado atual do init (valor local e sensível)

Este valor é o resultado atual da inicialização do Vault neste ambiente local do projeto. Ele deve ser tratado como secreto e armazenado em local confiável.

```bash
kubectl exec -n vault pod/vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json
```

Resultado atual observado:

```json
{
  "unseal_keys_b64": [
    "<VALOR_ATUAL_DA_CHAVE_DE_UNSEAL>"
  ],
  "root_token": "<VALOR_ATUAL_DO_TOKEN_RAIZ>"
}
```

> Esse valor foi gerado no ambiente local deste repositório e é válido apenas para esse cluster. Não compartilhe esse conteúdo fora do ambiente local e preserve-o em local seguro.

---

## 5) Destravar o Vault automaticamente

O instalador também executa automaticamente o unseal usando a chave armazenada em `/var/lib/kind-data/vault-bootstrap.json`. Não é necessário executar este comando manualmente.

Como referência, este é o comando executado internamente pelo script:

```bash
kubectl exec -n vault pod/vault-0 -- vault operator unseal <UNSEAL_KEY>
```

Como a configuração usa `key-shares=1` e `key-threshold=1`, basta uma chave para destravar.

---

## 6) Acessar a API e a UI

### API

```text
http://localhost:8200
```

### UI

```text
http://localhost:8200/ui
```

O projeto está configurado com `NodePort`, por isso o acesso é direto no host, sem `port-forward`.

---

## 7) Fazer login

Você pode usar o token raiz:

```bash
kubectl exec -n vault pod/vault-0 -- vault login
```

ou logar diretamente na UI com o mesmo token raiz gerado no comando de init.

O instalador também exibe o token de acesso e informa o caminho do arquivo de credenciais ao finalizar:

```text
🔑 Access Token: <ROOT_TOKEN>
🔐 Credentials stored at: /var/lib/kind-data/vault-bootstrap.json
```

---

## 8) Próximos passos recomendados

Depois que o Vault estiver inicializado e destravado, normalmente você faz:

- criar namespaces
- configurar policies
- criar secrets
- habilitar autenticação para aplicações
- conectar apps do cluster usando identidade e segredos

---

## 9) Observações importantes

- Não use `dev` mode em ambiente persistente, porque ele não mantém estado em reinicializações.
- O diretório em `/var/lib/kind-data/vault` é a escolha correta para este ambiente local `kind` no WSL/Ubuntu.
- Proteja o arquivo `/var/lib/kind-data/vault-bootstrap.json`, pois ele contém a chave de unseal e o token raiz.
- O cluster `kind` deve continuar com os `extraPortMappings` e os serviços em `NodePort` para manter a padronização do projeto.

---

