# About this Image

These are images for WP-CLI. They differ from `wordpress:cli` images in two ways:

1. `ssh` is available and installed in the image.
2. These images include a small utility, `f1-ext-install`, to simplify the task of installing common extensions. For example, to install Memcached, one only needs to add this to their Dockerfile:

   ```sh
   f1-ext-install pecl:memcached
   ```

## PHP Versions and Tags

- Currently supported by PHP:

  - `8.0`, `8.0-xdebug`
  - `7.4`, `7.4-xdebug`
  - `7.3`, `7.3-xdebug`

- End-of-life for legacy projects:
  - `7.2`, `7.2-xdebug`

The tags `7` and `8` are available for quick testing when a specific version isn't needed.

# License

Like the [base PHP image](https://github.com/docker-library/php) we use, this project is available under the terms of the MIT license. See [LICENSE](LICENSE) for more details.
