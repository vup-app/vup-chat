# Build web

./flutterw build web --web-renderer html
tar -cf web.tar ./build/web
scp web.tar covalent@vup-chat.jptr.tech:/home/covalent
ssh covalent@vup-chat.jptr.tech "cd /home/covalent && rm -rf /var/www/* && mkdir -p ./web && tar -xf ./web.tar -C ./web && mv web/build/web/* /var/www && rm -rf web web.tar"
rm web.tar

# Build desktop


# Build Android
