FROM php:8.3-cli

ARG USERNAME=symfony
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Dependencies
RUN apt-get update \
    && apt-get install -y \
    git \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    unzip \
    wget \
    zip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PHP Extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    pdo_pgsql \
    zip

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Castor JoliCode 
# https://castor.jolicode.com/getting-started/installation/#installation
RUN curl "https://castor.jolicode.com/install" | bash
RUN castor completion | sudo tee /etc/bash_completion.d/castor

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Working directory
WORKDIR /workspace

USER $USERNAME