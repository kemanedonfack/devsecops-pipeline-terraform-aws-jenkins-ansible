#!/bin/bash

# SonarQube installation
sudo apt-get upgrade -y
sudo apt update
sudo apt install openjdk-17-jre -y
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo apt install unzip -y
