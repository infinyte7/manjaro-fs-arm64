## Create rootfs from scratch
FROM scratch
ADD . /
RUN uname -a

## Update and install the base and sudo packages
## RUN pacman-mirrors -gf
RUN pacman-mirrors --country Germany,France,Austria \
    && pacman-key --init \
    && pacman-key --populate \
    && pacman -Syyuu --noconfirm base sudo manjaro-release

## Setup xfce4
RUN pacman -S tar wget sed --noconfirm

RUN edition="xfce" \
    && manjaro_packages="https://gitlab.manjaro.org/manjaro-arm/applications/arm-profiles/-/raw/master/editions/${edition}?inline=false" \
    && manjaro_services="https://gitlab.manjaro.org/manjaro-arm/applications/arm-profiles/-/raw/master/services/${edition}?inline=false" \
    && manjaro_overlays="https://gitlab.manjaro.org/manjaro-arm/applications/arm-profiles/-/archive/master/arm-profiles-master.tar?path=overlays/${edition}" \

    && packages=$(curl -sL "${manjaro_packages}" | sed -e 's/\s*#.*//;/^\s*$/d;s/\s*$//') \
    && pacman -S --needed --noconfirm $packages

## Install TigerVNC 10.1.1
RUN pacman -U /tigervnc-1.10.1-1-aarch64.pkg.tar.xz --noconfirm \
    && tar xf /usr/lib/a.tar.xz -C /usr/lib \
    && sed -i '27i IgnorePkg = tigervnc' /etc/pacman.conf

RUN paccache -rk0

## Setup TigerVNC
RUN mkdir -p /etc/skel/.vnc \
    && echo "#!/bin/sh" >> /etc/skel/.vnc/xstartup \
    && echo "unset SESSION_MANAGER" >> /etc/skel/.vnc/xstartup \
    && echo "export DISPLAY=:1" >> /etc/skel/.vnc/xstartup \
    && echo "export PULSE_SERVER=127.0.0.1" >> /etc/skel/.vnc/xstartup \
    && echo "pulseaudio --start" >> /etc/skel/.vnc/xstartup \
    && echo "[[ -r \${HOME}/.Xresources ]] && xrdb \${HOME}/.Xresources" >> /etc/skel/.vnc/xstartup \
    && echo "exec dbus-launch startxfce4" >> /etc/skel/.vnc/xstartup \
    && chmod -cf +x /etc/skel/.vnc/xstartup

RUN echo "Desktop=manjaro" >> /etc/skel/.vnc/config \
    && echo "Geometry=1024x768" >> /etc/skel/.vnc/config \
    && echo "SecurityTypes=VncAuth,TLSVnc" >> /etc/skel/.vnc/config \
    && echo "Localhost" >> /etc/skel/.vnc/config \

    && chmod +x /usr/local/bin/vncserver-start \
    && chmod +x /usr/local/bin/vncserver-stop
