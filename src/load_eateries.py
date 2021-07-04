from db import *

dsn = generate_dsn('config.json')

session = get_session(dsn)

with open('DPR_Eateries_001.json', "r") as file:
    data = json.load(file)

    eatery_list = []

    for row in data:
        eatery = Eatery(**row)
        eatery_list.append(eatery)

    session.add_all(eatery_list)

    session.commit()


result = session.query(Eatery).all()

for row in result:
   print("name: ", row.name)