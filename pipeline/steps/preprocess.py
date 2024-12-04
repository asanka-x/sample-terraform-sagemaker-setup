import argparse
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler())


if __name__ == '__main__':
    
    logger.info(f'Preprocessing job started.')
 
    parser = argparse.ArgumentParser()

    args, _ = parser.parse_known_args()

    logger.info(f"Received arguments {args}.")

    raise Exception("Something went wrong!")

    logger.info("Finished running processing job")













