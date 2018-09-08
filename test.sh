echo "Please enter the full DNS name of this machine (ie. git1.edge.app):"
read host_name
echo "Please enter an SSH private key with authorization to access github.com"
read ssh_key
echo "Please enter a CouchDB admin password"
read couchdb_admin_password
echo "Please enter a CouchDB user password"
read couchdb_user_password
echo "Please enter a seed server to synchronize with full URL. ie."
echo "https://username:password@git2.edge.app:6984"
read seed_server
