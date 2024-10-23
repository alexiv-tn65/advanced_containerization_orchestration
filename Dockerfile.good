# Используем минимальный образ Python
FROM python:3.11-slim

# Создаем нового пользователя
RUN useradd -m -s /bin/bash jupyteruser

# Устанавливаем необходимые зависимости и очищаем кэш
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    git \
    nano \
    && pip install --no-cache-dir jupyter pandas numpy matplotlib \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Открываем порт 8888 для доступа к Jupyter Notebook
EXPOSE 8888

# Создаём конфигурационный файл для Jupyter Notebook
RUN mkdir -p /home/jupyteruser/.jupyter && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /home/jupyteruser/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.port = 8888" >> /home/jupyteruser/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = ''" >> /home/jupyteruser/.jupyter/jupyter_notebook_config.py

# Установка рабочего каталога
WORKDIR /home/jupyteruser

# Создание volume с указанием точки монтирования
VOLUME ["/data"]

# Переключаемся на нового пользователя
USER jupyteruser

# Указываем команду для запуска Jupyter Notebook с уровнем логирования DEBUG
ENTRYPOINT ["jupyter", "notebook", "--config=/home/jupyteruser/.jupyter/jupyter_notebook_config.py", "--log-level=DEBUG"]