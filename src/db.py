import psycopg2
import sqlalchemy
import json

from sqlalchemy import create_engine
from sqlalchemy import Column, Date, Text, Integer
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base


def generate_dsn(path):
    with open(path, "r") as handler:

        data = json.load(handler)

        username = data["username"]
        password = data["password"]
        database = data["database"]

    dsn = 'postgresql://' + str(username) + ':' + str(password) + '@localhost/' + str(database)

    return dsn


def get_session(dsn):
    engine = create_engine(dsn, echo=True)
    Session = sessionmaker(engine)
    session = Session()

    return session


Base = declarative_base()


class Eatery(Base):
    __tablename__ = 'eatery'

    eatery_id = Column('eatery_id', Integer, primary_key=True)
    name = Column('name', Text)
    location = Column('location', Text)
    park_id = Column('park_id', Text)
    start_date = Column('start_date', Date)
    end_date = Column('end_date', Date)
    description = Column('description', Text)
    permit_number = Column('permit_number', Text)
    phone = Column('phone', Text)
    website = Column('website', Text)
    type_name = Column('type_name', Text)

    def __str__(self):
        return self.__repr__()
