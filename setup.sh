# This script will setup the dotFiles repository
# It will clone the repository and then setup the repository
# It will also setup the repository with the following:
# - git
# - vim
# - tmux
# - zsh
# - oh-my-zsh
# - powerlevel10k

# create a temp directory in the home directory
mkdir -p ~/temp
cd ~/temp

# clone repository https://github.com/atulpatildbz/dotFiles.git
git clone https://github.com/atulpatildbz/dotFiles.git

# ask if user wants to install zsh from oh-my-zsh
echo "Do you want to install zsh from oh-my-zsh? (y/n)"
read zsh

# if yes, install zsh from oh-my-zsh
if [ $zsh = "y" ]; then
    # install zsh from oh-my-zsh
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    # print installing zsh from oh-my-zsh
    echo "Installing zsh from oh-my-zsh"
    sh install.sh

    # print installing powerlevel10k theme
    echo "Installing powerlevel10k theme"
    # install powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # remove existing ZSH_THEME in .zshrc
    sed -i '/ZSH_THEME/d' ~/.zshrc

    # print applying powerlevel10k theme
    echo "Applying powerlevel10k theme"
    # set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc
    echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> ~/.zshrc
fi

# ask user if they want to install nvm
echo "Do you want to install nvm? (y/n)"
read nvm

# if yes, install nvm
if [ $nvm = "y" ]; then
    # install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

    # add NVM_DIR to .zshrc
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    # source zshrc
    source ~/.zshrc

    # install lts node with nvm
    nvm install --lts
fi

# ask user if they want to setup neovim
echo "Do you want to setup neovim? (y/n)"
read -r neovimSetup

# if yes, setup neovim
if [ "$neovimSetup" = "y" ]; then
    # print message "Installing neovim"
    echo "Installing neovim"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage

    # add alias in .zshrc
    echo "alias nvim='nvim.appimage'" >> ~/.zshrc

    # check if plug is installed
    if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
        # print "Plug doesn't exist. Installing plug"
        echo "Plug doesn't exist. Installing plug"
        # install plug
        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    # create ~/.config if it doesn't exist
    if [ ! -d ~/.config ]; then
        # print "Creating ~/.config"
        echo "Creating ~/.config"
        mkdir ~/.config
    fi

    # create a symbolic link to ~/dotFiles/neovim0.5/nvim in ~/.config
    ln -s ~/dotFiles/neovim0.5/nvim ~/.config/
    # print Created config for neovim
    echo "Created config for neovim"
    
    # ask user if they want to install tsserver lsp
    echo "Do you want to install tsserver lsp? (y/n)"
    read -r tsserverSetup
    # if yes, install tsserver lsp
    if [ "$tsserverSetup" = "y" ]; then
        # print message "Installing tsserver lsp"
        echo "Installing tsserver lsp"
        # install tsserver lsp
        npm install -g typescript typescript-language-server
    fi

    # ask user if they want to install python lsp
    echo "Do you want to install python lsp? (y/n)"
    read -r pythonSetup
    # if yes, install python lsp
    if [ "$pythonSetup" = "y" ]; then
        # print message "Installing python lsp"
        echo "Installing python lsp"
        # install python lsp
        pip3 install 'python-lsp-server[all]'
    fi

    # print adding snippets
    echo "Adding snippets"
    # create symbolic link to ~/dotFiles/neovim0.5/snippets/.vsnip in ~/
    ln -s ~/dotFiles/neovim0.5/snippets/.vsnip ~/
fi

# install ripgrep if it doesn't exist
if [ ! -f ~/.local/bin/rg ]; then
    # print "Installing ripgrep"
    echo "Installing ripgrep"
    # install ripgrep
    $ curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
    $ sudo dpkg -i ripgrep_12.1.1_amd64.deb
fi

# create a symbolic link to ~/dotFiles/tmux.conf in ~/.tmux.conf
# rename file if it exists
if [ -f ~/.tmux.conf ]; then
    # delete tmux.conf.old file if it exists
    if [ -f ~/.tmux.conf.old ]; then
        rm ~/.tmux.conf.old
    fi
    mv ~/.tmux.conf ~/.tmux.conf.old
    ln -s ~/dotFiles/tmux.conf ~/.tmux.conf
    # print tmux.conf done
    echo "tmux.conf done"
fi

# create a symbolic link for gitconfig
# rename file if it exists
if [ -f ~/.gitconfig ]; then
    # remove .gitconfig.old file if it exists
    if [ -f ~/.gitconfig.old ]; then
        rm ~/.gitconfig.old
    fi
    mv ~/.gitconfig ~/.gitconfig.old
    ln -s ~/dotFiles/git/gitconfig ~/.gitconfig
    # print gitconfig done
    echo "gitconfig done"
fi