# Build web

flutter build web --web-renderer html
tar -cf web.tar ./build/web
scp web.tar covalent@vup-chat.jptr.tech:/home/covalent
ssh covalent@vup-chat.jptr.tech "cd /home/covalent && rm -rf ./web && mkdir -p ./web web2 && tar -xf ./web.tar -C ./web2 && mv web2/build/web/* web && rm -rf web2 web.tar"
rm web.tar

# Build desktop


# Build Android
