# guia_turismo

App Flutter do Guia de Turismo (atividade da aula de 14/10) com login, cadastro de usuário e cadastro de lugares.

API: https://guia.liliaborges.com.br/api-docs/

## Estrutura (mesma arquitetura da aula)

- `lib/controller` – ChangeNotifier (Provider): auth, lugares, câmera, tema
- `lib/services` – chamadas HTTP e sessão (token em SharedPreferences)
- `lib/models` – LugaresModel
- `lib/screens` – login, registro, lugares, cadastro de lugar

## Fluxo

Login -> lista de lugares -> botão "+" -> cadastro de lugar (envia o token Bearer).

## Rodar

```
flutter pub get
flutter run
```
