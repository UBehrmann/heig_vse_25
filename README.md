# HEIG VSE 2025

## Pull + merge origin

```bash
git pull origin main
git fetch origin
git merge origin/main
```

## Run vsim

```bash
vsim -c -do "run -all" work.tb_analyseur_paquets
vsim -do "do sim.do all 0 0"
```

## Run vrun

```bash
vrun directed
```