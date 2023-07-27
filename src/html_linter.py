from bs4 import BeautifulSoup

def html_linter(html_file):
    try:
        soup = BeautifulSoup(html_file, 'html.parser')
        print("HTML syntax is correct.")
    except Exception as e:
        print("HTML syntax error: ", e)

if __name__ == '__main__':
    with open('index.html') as file:
        html_linter(file)
