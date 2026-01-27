import logging
import logging.config

def configure_logging():
    logging.config.fileConfig("logging.conf")
    return logging.getLogger()
