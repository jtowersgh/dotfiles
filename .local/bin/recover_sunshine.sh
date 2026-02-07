# Recover Sunshine/Moonlight remotely
for S in $(loginctl list-sessions | awk '/jeff/ {print $1}'); do
	TYPE=$(loginctl show-session $S -p Type --value)
	TTY=$(loginctl show-session $S -p TTY --value)
        # Skip your SSH session (TTY not empty for pts/X)
    	if [[ "$TYPE" == "wayland" || "$TYPE" == "x11" ]] && [[ -z "TTY" ]]; then
	        echo "Terminating stale graphical session $S..."
        loginctl terminate-session $S
        fi
done
echo "Restarting SDDM..."
sudo systemctl restart sddm
echo "Restarting Sunshine user service..."
systemctl --user restart sunshine
echo "Done! Check logs with: journalctl --user -u sunshine -n 50"

