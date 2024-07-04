FROM debian:bullseye

# Install git, supervisor, VNC, & X11 packages
RUN set -ex; \
    apt-get update; \
    apt-get install -y \
      bash \
      fluxbox \
      git \
      net-tools \
      novnc \
      supervisor \
      x11vnc \
      xterm \
      xvfb\
      openjdk-11-jdk \
      sudo\
      wget \
      unzip \
      nano \
      git \
      procps \
      libpulse0


# Set environment variables
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Create necessary directories
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools/latest

# Download and install Android SDK command line tools
RUN cd ${ANDROID_HOME}/cmdline-tools/latest && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O android_tools.zip && \
    unzip android_tools.zip && \
    mv cmdline-tools/* . && \
    rm -rf cmdline-tools android_tools.zip

# Install SDK packages
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_HOME} \
    "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.3" \
    "emulator" \
    "system-images;android-33;android-automotive;x86_64"

# Create and start the emulator
RUN echo "no" | ${ANDROID_HOME}/cmdline-tools/latest/bin/avdmanager create avd -n automotive_emulator -k "system-images;android-33;android-automotive;x86_64" --force


# Setup demo environment variables
ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=no \
    RUN_FLUXBOX=yes
COPY . /app
CMD ["/app/entrypoint.sh"]
EXPOSE 8080 5555
