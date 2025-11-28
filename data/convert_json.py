import pandas as pd

# Read the file
df = pd.read_csv('fitness_data.xlsx - Sheet1.csv')

# Select and rename relevant columns for the database
clean_df = df[['Exercise', 'Difficulty Level', 'Target Muscle Group', 'Primary Equipment']].copy()
clean_df.columns = ['name', 'difficulty', 'target_muscle', 'equipment']

# Save to JSON
clean_df.to_json('exercises.json', orient='records', indent=4)

print("Conversion complete! Saved to exercises.json")