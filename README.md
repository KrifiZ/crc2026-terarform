# Pierwsze kroki z Terraform w Azure – Infrastructure as Code

Projekt stworzony w ramach kursu online **"Pierwsze kroki z Terraform w Azure – Twoja droga do Infrastructure as Code"** organizowanego przez Accenture.

## O projekcie

Repozytorium demonstruje praktyczne zastosowanie Terraform do automatycznego zarządzania infrastrukturą w Azure. Projekt wdraża **Azure Key Vault** wraz z politykami dostępu, kluczem szyfrowania i sekretem – w pełni zautomatyzowany przez pipeline CI/CD w GitHub Actions.

## Infrastruktura

Terraform provisionuje następujące zasoby w Azure:

| Zasób | Opis |
|---|---|
| `azurerm_key_vault` | Key Vault z włączonym soft-delete i purge protection |
| `azurerm_key_vault_access_policy` | Polityki dostępu dla service principal i użytkownika |
| `azurerm_key_vault_key` | Klucz szyfrowania RSA 2048-bit |
| `azurerm_key_vault_secret` | Sekret – losowe hasło 24-znakowe |
| `random_password` | Generator bezpiecznego hasła |

Zasoby są wdrażane do istniejącej grupy zasobów `rg-crc2026-student-203-lab`.

## Struktura repozytorium

```
.
├── .github/
│   └── workflows/
│       ├── deploy.yml      # Pipeline: plan + apply (wyzwalany przez push do main)
│       └── destroy.yml     # Pipeline: plan-destroy + destroy (wyzwalany ręcznie)
├── main.tf                 # Główne zasoby Azure
├── providers.tf            # Konfiguracja providerów i backendu
├── data.tf                 # Dane wejściowe (resource group, client config)
├── locals.tf               # Zmienne lokalne (prefix, tagi)
└── variables.tf            # Zmienne wejściowe
```

## Pipeline CI/CD

### Deploy (`deploy.yml`)

Uruchamiany automatycznie przy każdym push do gałęzi `main`.

```
push → main
         │
         ▼
    ┌─────────┐
    │  Plan   │  terraform fmt -check + init + plan
    └────┬────┘
         │
         ▼
    ┌─────────┐
    │  Apply  │  (wymaga ręcznej akceptacji w środowisku "production")
    └─────────┘
```

### Destroy (`destroy.yml`)

Uruchamiany ręcznie przez `workflow_dispatch`.

```
manual trigger
         │
         ▼
    ┌──────────────┐
    │  Plan Destroy│  terraform plan -destroy
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │    Destroy   │  (wymaga ręcznej akceptacji w środowisku "production")
    └──────────────┘
```

## Wymagania

### Narzędzia lokalne

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.x
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

### Sekrety GitHub Actions

Skonfiguruj następujące sekrety i zmienne w ustawieniach repozytorium:

| Nazwa | Typ | Opis |
|---|---|---|
| `ARM_CLIENT_ID` | Secret | Client ID service principal |
| `ARM_CLIENT_SECRET` | Secret | Client Secret service principal |
| `ARM_SUBSCRIPTION_ID` | Secret | ID subskrypcji Azure |
| `ARM_TENANT_ID` | Secret | ID tenanta Azure AD |
| `BACKEND_RESOURCE_GROUP` | Variable | Resource group dla stanu Terraform |
| `BACKEND_STORAGE_ACCOUNT` | Variable | Storage Account dla stanu Terraform |
| `BACKEND_CONTAINER` | Variable | Kontener blob dla stanu Terraform |
| `TF_VAR_USER_OBJECT_ID` | Variable | Object ID użytkownika z dostępem do Key Vault |

## Uruchomienie lokalne

```bash
# Logowanie do Azure
az login

# Inicjalizacja backendu
terraform init \
  -backend-config="resource_group_name=<RG>" \
  -backend-config="storage_account_name=<SA>" \
  -backend-config="container_name=<CONTAINER>" \
  -backend-config="key=terraform.tfstate"

# Podgląd zmian
terraform plan -var="user_object_id=<OBJECT_ID>"

# Wdrożenie
terraform apply -var="user_object_id=<OBJECT_ID>"
```

## Kurs

Projekt powstał podczas kursu:

**Pierwsze kroki z Terraform w Azure – Twoja droga do Infrastructure as Code**
- Organizator: Accenture
- Poziom: średnio zaawansowany
- Program kursu:
  1. Wprowadzenie do IaC i Terraform
  2. Podstawy składni Terraform
  3. Zmienne i Output
  4. Moduły i organizacja kodu
  5. Stan i zarządzanie nim
  6. Pierwszy pipeline z Terraform
