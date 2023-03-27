#!/bin/bash

# Script para criar backups completos e incrementais compactados de um diretório especificado,
# em horários pré-definidos e excluir backups antigos que foram criados há mais de 35 dias.

# Autor: Lucas Caitano
# Data de criação: 2023-03-24

# Configurações

backup_dir="/backup"
incremental_dir="/backup-incremental"
source_dir="/sistema"


datetime_format="%Y-%m-%d_%H-%M-%S" # Formato da data/hora para nomear os backups

retention_period_days=35 # Período de retenção dos backups antigos (em dias)

# Define o nome do arquivo de log
LOG_COMPLETO="/var/log/backup_completo.log"
LOG_INCREMENTAL="/var/log/backup_incremental.log"

# Cria os diretórios de backup, se não existirem
if [ ! -d "$backup_dir" ]; then
  mkdir "$backup_dir"
fi

if [ ! -d "$incremental_dir" ]; then
  mkdir "$incremental_dir"
fi

# Cria o backup completo, se a hora atual for 17
if [ $(date "+%H") -eq 17 ]; then
  datetime=$(date "+$datetime_format")
  backup_completo="backup_completo_$datetime.tar.gz" # Nome dos Arquivos
  
  if tar -czf "$backup_dir/$backup_completo" "$source_dir"; then
    echo "Backup completo criado em $datetime $backup_dir/$backup_completo " >> "$LOG_COMPLETO"
  else
    echo "Erro ao criar backup completo $datetime"  >> "$LOG_COMPLETO"
	
  fi
fi

# Cria o backup incremental, se a hora atual for 11 ou 15
if [ $(date "+%H") -eq 11 ] || [ $(date "+%H") -eq 15 ]; then
  datetime=$(date "+$datetime_format")
  incremental_backup_name="incremental_backup_$datetime.tar.gz"
  incremental_snapshot_file="$incremental_dir/incremental_snapshot_$datetime.txt"

  if tar -czf "$incremental_dir/$incremental_backup_name" --listed-incremental="$incremental_snapshot_file" "$source_dir"; then
    echo "Backup incremental criado em $datetime $incremental_dir/$incremental_backup_name" >> "$LOG_INCREMENTAL"
  else
    echo "Erro ao criar backup incremental $datetime" >> "$LOG_INCREMENTAL"
  fi
fi

# Exclui backups antigos
find "$backup_dir" -type f -name "backup_completo*.tar.gz" -mtime +$retention_period_days -exec rm {} \;
find "$incremental_dir" -type f -name "incremental_backup*.tar.gz" -mtime +$retention_period_days -exec rm {} \;