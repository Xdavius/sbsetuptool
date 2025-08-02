# sbsetuptool
A tool to create mok and sign kernels modules and dkms modules(also Custom like Xanmod with sign-file included)

# Dependencies

```
sudo apt install apt install git mokutil sbsigntool dkms linux-headers-amd64
```

# USAGE

Add LANG= to make install for English version. Default is French
```
sudo make install LANG=en
sudo sbsetuptool
```
