# claude-setup

Fikret'in Claude Code ayarları: skill'ler, genel kurallar ve kurulum betikleri. Private repo.

## Öbür bilgisayarda ne yapacaksın

1. Terminalde bir kere GitHub'a gir (tek elle yapılacak şey bu):
   ```powershell
   gh auth login
   ```
2. Claude'a şunu yaz, gerisini o halleder:

   > `gh repo clone FikretGezer/claude-setup "$HOME\Desktop\Claude Projects\claude-setup"` ile repoyu indir, içindeki `INSTRUCTIONS-FOR-CLAUDE.md` dosyasını oku ve dediklerini baştan sona uygula. Bana dokunduracak bir şey bırakma.

3. Bitince yeni bir oturum aç ve `/visual` yaz.

`gh` yoksa Claude onu `winget` ile kurar. Eklenti komutlarını (`/plugin ...`) Claude çalıştıramazsa sana söyler, onları yazman gerekir.

## İçindekiler

| Dosya | Ne işe yarar |
|---|---|
| `INSTRUCTIONS-FOR-CLAUDE.md` | Öbür bilgisayardaki Claude için adım adım talimat |
| `scripts/install.ps1` | visual-library'yi indirir, skill'leri ve kuralları kurar (tekrar çalıştırmak güvenli) |
| `scripts/verify.ps1` | Her şeyin kurulduğunu PASS/FAIL ile kontrol eder |
| `scripts/export.ps1` | Ana PC'de skill değiştirince yeni halini bu repoya alır |
| `skills/visual`, `skills/ship` | Skill'lerin kendisi (`{{LIB}}` yer tutucusu kurulumda doldurulur) |
| `skills/caveman` | Resmi caveman eklentisi yoksa kullanılan yedek |
| `claude-md.template.md` | `~/.claude/CLAUDE.md` içine eklenen kurallar |

## Güncelleme

- Ana PC: skill'i değiştir, `scripts/export.ps1` çalıştır, commit ve push et.
- Öbür PC: `git pull`, sonra `scripts/install.ps1` ve `scripts/verify.ps1`.

Görsellerin kendisi ayrı repoda: `FikretGezer/visual-library`.
