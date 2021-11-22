import requests, json
from pamda import pamda

settings=pamda.read_json("../settings.json")

client = requests.session()
client.get(settings.get('url')+'/login/')  # sets the cookie
login_data = {
    'username':settings.get('username'),
    'password':settings.get('password'),
    'csrfmiddlewaretoken':client.cookies.get('csrftoken')
}
client.post(
    settings.get('url')+'/login/',
    data=login_data,
    headers={'Referer':settings.get('url')+'/login/'}
)
r0=client.get(settings.get('url')+'/outputs/')
data=json.loads(r0.text)

def flatten(data):
    user=data.get('user')
    user_input=data.get('userInput')
    user_dom={'avgDomPct':data.get('avgDomPct')}
    scenario_dom_pct={str(key)+" - Dom Pct":value for key, value in data.get('scenarioDomPct').items()}
    output=data.get('output')
    output_flat={}
    for scen_name, scen_data in output.items():
        for scen_stat, scen_val in scen_data.items():
            output_flat[f'{scen_name} - {scen_stat}']=scen_val

    return {
        **user,
        **user_input,
        **user_dom,
        **scenario_dom_pct,
        **output_flat
    }


formatted_data=[flatten(i) for i in data]

pamda.write_csv('../output.csv',formatted_data)
