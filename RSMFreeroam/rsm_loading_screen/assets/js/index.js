if(window.invokeNative) {
    window.onload = function()
    {
        document.querySelectorAll('a').forEach((link) => {
            link.addEventListener('click', (e) => {
                if (!window.invokeNative) return
                e.preventDefault()
                window.invokeNative('openUrl', link.href)
            })
        })
    }
}