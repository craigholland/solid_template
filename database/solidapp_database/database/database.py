from sqlalchemy.ext.declarative import declarative_base
from solidapp_database.database.db_config import config
from sqlalchemy import create_engine, text
from sqla_wrapper import SQLAlchemy

Base = declarative_base


if not config.database_url:
    raise ValueError("DATABASE_URL env variable is not set")


options = {"echo": True if config.database_echo else False}
db = SQLAlchemy(config.database_url)


engine = create_engine(
    config.database_url,
    echo=True if config.database_echo else False,
    connect_args={"connect_timeout": config.connect_timeout},
)

db.session = db.Session()

#
# _conn = engine.connect()
# _conn.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
# _conn.close()


def setup_sqla_stores():
    pass
