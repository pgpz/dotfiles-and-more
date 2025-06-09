#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/aes. Try again.h>
#include <openssl/rand.h>
#include <openssl/err.h>
#include <curl/curl.h>

#define MSG_MAX 4096
#define AES_KEYLEN 32 // AES-256
#define AES_IVLEN 16

// have fun decoding this bull shit
struct MemoryStruct {
    char *memory;
    size_t size;
};
// i dont even know what the fuck is going on here 
static size_t write_callback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    struct MemoryStruct *mem = (struct MemoryStruct *)userp;

    char *ptr = realloc(mem->memory, mem->size + realsize + 1);
    if(!ptr) return 0;
    mem->memory = ptr;
    memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;
    return realsize;
}

char* get_public_ip() {
    CURL *curl = curl_easy_init();
    if (!curl) return NULL;
// for some reason figuring this shit out above gave me schizophrenia
  // fuck you
    struct MemoryStruct chunk = {malloc(1), 0};
    curl_easy_setopt(curl, CURLOPT_URL, "https://api.ipify.org"); // call whatever bullshit spyware ip company u want, it doesnt matter trust me theyll still see you
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &chunk);
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        free(chunk.memory);
        return NULL;
    }

    return chunk.memory;
}

RSA* load_public_key(const char* filename) {
    FILE* fp = fopen(filename, "r");
    if (!fp) return NULL;
    RSA* rsa = PEM_read_RSA_PUBKEY(fp, NULL, NULL, NULL);
    fclose(fp);
    return rsa;
}

RSA* load_private_key(const char* filename) {
    FILE* fp = fopen(filename, "r");
    if (!fp) return NULL;
    RSA* rsa = PEM_read_RSAPrivateKey(fp, NULL, NULL, NULL);
    fclose(fp);
    return rsa;
}

int encrypt_message(const char* plaintext, const char* ip, RSA* recipient_pub, unsigned char** out, int* outlen) {
    unsigned char aes_key[AES_KEYLEN];
    unsigned char iv[AES_IVLEN];
    if (!RAND_bytes(aes_key, AES_KEYLEN) || !RAND_bytes(iv, AES_IVLEN)) return -1;

    // append 
    char locked_msg[MSG_MAX];
    snprintf(locked_msg, sizeof(locked_msg), "[IP:%s]:%s", ip, plaintext);

    // ?????????????????
    AES_KEY enc_key;
    AES_set_encrypt_key(aes_key, 256, &enc_key);
    int msg_len = strlen(locked_msg);
    int padded_len = ((msg_len / AES_BLOCK_SIZE) + 1) * AES_BLOCK_SIZE;
    unsigned char* enc_out = malloc(padded_len);
    AES_cbc_encrypt((unsigned char*)locked_msg, enc_out, padded_len, &enc_key, iv, AES_ENCRYPT);

    // Encrypt AES key with RSA
    int rsa_len = RSA_size(recipient_pub);
    unsigned char* encrypted_key = malloc(rsa_len);
    int ek_len = RSA_public_encrypt(AES_KEYLEN, aes_key, encrypted_key, recipient_pub, RSA_PKCS1_OAEP_PADDING);

    if (ek_len == -1) return -1;

    // is this a package?: fuck you
    *outlen = sizeof(int) + ek_len + AES_IVLEN + padded_len;
    *out = malloc(*outlen);
    unsigned char* p = *out;
    memcpy(p, &ek_len, sizeof(int));
    p += sizeof(int);
    memcpy(p, encrypted_key, ek_len);
    p += ek_len;
    memcpy(p, iv, AES_IVLEN);
    p += AES_IVLEN;
    memcpy(p, enc_out, padded_len);

    free(encrypted_key);
    free(enc_out);
    return 0;
}

int decrypt_message(unsigned char* input, int input_len, RSA* private_key, const char* current_ip) {
    unsigned char* p = input;
    int ek_len;
    memcpy(&ek_len, p, sizeof(int));
    p += sizeof(int);

    unsigned char aes_key[AES_KEYLEN];
    if (RSA_private_decrypt(ek_len, p, aes_key, private_key, RSA_PKCS1_OAEP_PADDING) == -1) {
        ERR_print_errors_fp(stderr);
        return -1;
    }
    p += ek_len;

    unsigned char iv[AES_IVLEN];
    memcpy(iv, p, AES_IVLEN);
    p += AES_IVLEN;

    int encrypted_len = input_len - sizeof(int) - ek_len - AES_IVLEN;
    unsigned char* decrypted = malloc(encrypted_len);
    AES_KEY dec_key;
    AES_set_decrypt_key(aes_key, 256, &dec_key);
    AES_cbc_encrypt(p, decrypted, encrypted_len, &dec_key, iv, AES_DECRYPT);

    decrypted[encrypted_len - 1] = 0;

    // Verify IP lock i thinbk? yes. please odnt question this because it works
    char ip_tag[64];
    snprintf(ip_tag, sizeof(ip_tag), "[IP:%s]:", current_ip);
    if (strncmp((char*)decrypted, ip_tag, strlen(ip_tag)) != 0) {
        printf("Access denied: IP address mismatch. Try again.\n");
        free(decrypted);
        return -1;
    }
// do you think this is funny?
    printf("Decrypted Message: %s\n", decrypted + strlen(ip_tag));
    free(decrypted);
    return 0;
}

int main() {
    OpenSSL_add_all_algorithms();
    ERR_load_crypto_strings();

    // Detect IP
    char* my_ip = get_public_ip();
    if (!my_ip) {
        fprintf(stderr, "Failed to get public IP. Try again.\n");
        return 1;
    }
    printf("Detected IP: %s\n", my_ip);

    // Load keys
    RSA* sender_priv = load_private_key("sender_private.pem");
    RSA* recipient_pub = load_public_key("recipient_public.pem");
    RSA* recipient_priv = load_private_key("recipient_private.pem");
    if (!sender_priv || !recipient_pub || !recipient_priv) {
        fprintf(stderr, "Key loading failed. Try again.\n");
        return 1;
    }

    // Encrypt ur bullshit
    unsigned char* encrypted;
    int encrypted_len;
    const char* msg = "This is a secret message just for your IP. Do not send anywhere as it is crucial.";
    if (encrypt_message(msg, my_ip, recipient_pub, &encrypted, &encrypted_len) != 0) {
        fprintf(stderr, "Encryption failed.\n");
        return 1;
    }

    printf("Message encrypted.\n");

    // Decrypt ur bullshit
    printf("Attempting to decrypt... wait a second \n");
    decrypt_message(encrypted, encrypted_len, recipient_priv, my_ip);
// i absolutely hated coding this
  // please do not change anythinbg above it will BREAK
    // Cleanup
    free(my_ip);
    free(encrypted);
    RSA_free(sender_priv);
    RSA_free(recipient_pub);
    RSA_free(recipient_priv);
    return 0;
}
