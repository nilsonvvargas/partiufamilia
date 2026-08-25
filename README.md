# 🌴 Maceió Travel Hub - Flutter MiniApps & Node.js BFF (Supabase)

Projeto de estudo e laboratório prático de arquitetura corporativa baseado em **Micro-frontends / MiniApps em Flutter** orquestrados por um **BFF (Backend-for-Frontend) em Node.js com TypeScript** e persistência no **Supabase**.

---

## 🏛️ Arquitetura do Projeto

```
maceio_travel_hub/
├── bff/                                # Backend For Frontend (Node.js + Express + TypeScript)
│   ├── src/
│   │   ├── config/supabase.ts          # Conexão com Supabase Client
│   │   ├── data/seedData.ts            # Base de dados estruturada da viagem a Maceió
│   │   ├── modules/                    # Módulos espelhados do BFF
│   │   │   ├── dashboard/              # Agregador Home (resumo 1-roundtrip)
│   │   │   ├── itinerary/              # Roteiro & Maré (Maragogi, Milagres, Gunga, Francês)
│   │   │   ├── expenses/               # Controle financeiro & rateio de despesas
│   │   │   ├── dining/                 # Jantares & Gastronomia (Bodega do Sertão, etc.)
│   │   │   ├── stay/                   # Pousada, check-in, regras e Wi-Fi
│   │   │   ├── packing/                # Checklist de bagagem interativo
│   │   │   └── contacts/               # Contatos de jangadeiros, guias e emergência
│   │   ├── scripts/seed_supabase.ts    # Script DDL e auto-seed no Supabase
│   │   └── server.ts                   # Servidor Express principal
│   ├── package.json
│   └── tsconfig.json
│
└── mobile/                             # Ecossistema Modular Flutter
    ├── packages/
    │   ├── core/                       # HTTP Client, MiniApp Contracts e Service Locator (DI)
    │   ├── design_system/              # Identidade visual tropical Maceió (Cores, Tipografia, Cards, Botões)
    │   │
    │   └── miniapps/                   # MiniApps 100% Desacoplados
    │       ├── miniapp_itinerary/      # MiniApp de Roteiro e Passeios
    │       ├── miniapp_expenses/       # MiniApp de Gestão Financeira e Lançamentos
    │       ├── miniapp_dining/         # MiniApp de Jantares e Restaurantes
    │       ├── miniapp_stay/           # MiniApp de Estadia e Hospedagem
    │       ├── miniapp_packing/        # MiniApp de Checklist de Mala
    │       └── miniapp_contacts/       # MiniApp de Contatos e Guias
    │
    └── app_host/                       # Shell App agregador, registro de MiniApps e Router
```

---

## 🚀 Como Executar o Projeto

### 1. Iniciar o BFF (Node.js + TypeScript)
```bash
cd bff
npm install
npm run dev
```
O servidor estará rodando em `http://localhost:3001` com os endpoints:
- `GET /api/v1/dashboard` (Resumo consolidado para a Home)
- `GET /api/v1/itinerary` (Passeios)
- `GET /api/v1/expenses` (Gastos)
- `GET /api/v1/dining` (Jantares)
- `GET /api/v1/stay` (Hospedagem)
- `GET /api/v1/packing` (Mala)
- `GET /api/v1/contacts` (Contatos)

*(Opcional: Para rodar o seed no Supabase: `npm run seed`)*

---

### 2. Executar o App Flutter (Host Shell)
```bash
cd mobile/app_host
flutter pub get
flutter run -d chrome  # ou windows, android emulator
```

---

## 🗄️ Integração com Supabase
- **URL**: `https://tshoyechnrdigebnmwql.supabase.co`
- **Publishable Key**: `sb_publishable_VcrsQs6emj0GFE20-5G_Tw_Qiq9vyDM`
- **DDL SQL**: O script SQL com o esquema completo de tabelas está disponível em [`bff/src/scripts/seed_supabase.ts`](file:///C:/Users/nilso/.gemini/antigravity-ide/scratch/maceio_travel_hub/bff/src/scripts/seed_supabase.ts).
- O BFF possui mecanismo resiliente de *fallback*: se as tabelas ainda não existirem no Supabase, ele responde instantaneamente com a base em memória e tenta sincronizar assim que as tabelas forem criadas.

---

## 💡 Principais Padrões Arquiteturais Aplicados
1. **Contrato de MiniApp (`MiniAppContract`)**: Permite que novos miniapps sejam adicionados sem modificar a lógica interna de outros módulos.
2. **Dependency Injection Centralizada (`ServiceLocator`)**: Injeção desacoplada de serviços e clientes de rede.
3. **BFF Pattern**: Reduz a complexidade do cliente mobile agregando dados da viagem (clima, próximo passeio, progresso da mala e hospedagem) em uma única requisição inicial.
4. **Design System Modular**: Tokens padronizados de cores alagoanas (Turquesa Pajuçara, Coral, Areia e Sol) e componentes reutilizáveis.
