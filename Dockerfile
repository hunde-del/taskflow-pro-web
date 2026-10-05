# Use the officially recommended community stable base image
FROM eclipse-temurin:17-jre-focal

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install graphic rendering tools, VNC protocols, and web streaming layers
RUN apt-get update && apt-get install -y \
    xvfb \
    fluxbox \
    x11vnc \
    novnc \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Establish deployment workspace parameters
WORKDIR /app

# Copy the compiled Java desktop artifact into the container filesystem
COPY TaskFlowPro.jar /app/TaskFlowPro.jar

# Configure execution window dimensions and environmental flags
ENV DISPLAY=:1
ENV SCREEN_WIDTH=1024
ENV SCREEN_HEIGHT=768
ENV SCREEN_DEPTH=24

# Copy supervisor launch configuration sheet
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port 8080 for web browser traffic
EXPOSE 8080

# Trigger supervisor to keep all services running together
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
