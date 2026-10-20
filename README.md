# Sincronizare automată de fișiere între mașini

Proiect realizat la practica de domeniu din anul II, la Academia Tehnică Militară „Ferdinand I”, Facultatea de Sisteme Informatice și Securitate Cibernetică.

## Despre proiect

Aplicația ține un director de pe o mașină la zi pe una sau mai multe mașini separate, fără să fie nevoie de un buton de sincronizare. Salvați un fișier, iar el apare automat și pe destinație. Ideea pornește de la Syncthing, dar în varianta aceasta totul este făcut doar cu scripturi Bash și utilitare care există deja în Linux.

Mașina pe care lucrați este **Master**, iar cele pe care ajung fișierele sunt **Slave**. Aplicația a fost testată pe două mașini virtuale separate și poate trimite fișierele către mai multe mașini Slave în același timp.

## Cum funcționează

Aplicația se bazează pe două mecanisme care lucrează împreună.

**1. Sincronizare în timp real**
- `inotifywait` urmărește directorul local și observă când un fișier este salvat.
- Fișierul este trimis pe mașina destinație cu `scp`, prin SSH, sub formă de fișier temporar (`.tmp`). Astfel, originalul nu este suprascris direct în timpul transferului.
- Înainte de înlocuire, `lsof` verifică dacă fișierul de pe destinație este deschis de vreun proces. Dacă este, nu se suprascrie nimic și apare un mesaj în terminal.
- Dacă fișierul este liber, cel temporar îl înlocuiește pe cel vechi.

**2. Sincronizare totală periodică**
- La un interval configurabil (implicit 10 minute), `cron` pornește o verificare completă a directoarelor.
- Se compară sumele de control (`md5sum`) ale fișierelor de pe cele două mașini, iar cele care diferă sunt trimise din nou. Fișierele nemodificate nu se retransmit.

## Utilitarele folosite

| Utilitar | Rol în proiect |
|---|---|
| inotify-tools (`inotifywait`) | detectarea fișierelor modificate în timp real |
| ssh / scp | transferul securizat al fișierelor, cu autentificare pe bază de chei |
| md5sum | compararea conținutului fișierelor de pe cele două mașini |
| lsof | verificarea dacă un fișier de pe destinație este folosit de alt proces |
| cron | rularea automată a sincronizării totale la interval fix |

## De ce sincronizarea merge într-un singur sens

Sincronizarea este unidirecțională, de la Master la Slave, pentru a evita o buclă infinită. Dacă ambele mașini ar urmări directorul cu `inotify`, un fișier trimis de pe x pe y ar fi văzut de y ca o modificare nouă și trimis înapoi pe x. X l-ar vedea la rândul lui ca modificat și l-ar retrimite, iar procesul s-ar repeta la nesfârșit.

## Ce găsiți în repo

| Fișier | Rol |
|---|---|
| `sync_script.sh` | scriptul principal: monitorizare în timp real și transfer către Slave |
| `sync_reconciliere.sh` | sincronizarea totală, pe baza sumelor de control |
| `setup_cron.sh` | programează sincronizarea periodică la intervalul dat |
| `stop_cron.sh` | oprește sincronizarea periodică |
| `setari.conf` | fișierul de configurare |
| `DocumentCerinte.docx` | cerințele aplicației și documentarea utilitarelor |
| `DocumentTestare.docx` | planul de testare al aplicației |
| `DocumentTestareUtilitare.docx` | testele făcute pe fiecare utilitar în parte |

## Rulare

Din directorul proiectului, rulați:

```bash
./sync_script.sh        # pornește monitorizarea în timp real
./setup_cron.sh 10      # activează sincronizarea totală la fiecare 10 minute
./stop_cron.sh          # oprește sincronizarea periodică
```

## Testare

Planul de testare conține 7 scenarii, descrise în `DocumentTestare.docx`:

1. detectarea modificărilor în timp real
2. copierea prin fișier temporar
3. blocarea suprascrierii unui fișier deschis pe destinație
4. sincronizarea doar a fișierelor modificate, pe baza sumelor de control
5. programarea sincronizării periodice, fără duplicate în cron
6. trimiterea către mai multe mașini Slave
7. oprirea sincronizării periodice

Înainte de integrare, fiecare utilitar a fost testat separat. Detaliile se găsesc în `DocumentTestareUtilitare.docx`.

## Limitări

- Sincronizarea merge doar de la Master la Slave.
- Modificările nu sunt îmbinate (merge). Dacă un fișier diferă, versiunea de pe Master o înlocuiește pe cea de pe Slave, dar numai după verificarea sumelor de control și a faptului că fișierul nu este în uz.

## Autor

Ciocan Andrei-Șerban, grupa C-112C
Coordonator: Slt. ing. Alexandra-Ioana Buzățoiu
